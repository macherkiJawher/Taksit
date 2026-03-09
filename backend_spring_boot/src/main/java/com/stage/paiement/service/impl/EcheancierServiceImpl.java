package com.stage.paiement.service.impl;

import com.stage.paiement.entity.*;
import com.stage.paiement.enums.StatutEcheancier;
import com.stage.paiement.enums.StatutMensualite;
import com.stage.paiement.exception.BadRequestException;
import com.stage.paiement.exception.ResourceNotFoundException;
import com.stage.paiement.repository.ClientRepository;
import com.stage.paiement.repository.EcheancierRepository;
import com.stage.paiement.repository.MensualiteRepository;
import com.stage.paiement.repository.PrestataireRepository;
import com.stage.paiement.service.EcheancierService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

@Service
public class EcheancierServiceImpl implements EcheancierService {

    private final EcheancierRepository echeancierRepository;
    private final ClientRepository clientRepository;
    private final PrestataireRepository prestataireRepository;
    private final MensualiteRepository mensualiteRepository;

    public EcheancierServiceImpl(EcheancierRepository echeancierRepository,
                                 ClientRepository clientRepository,
                                 PrestataireRepository prestataireRepository,
                                 MensualiteRepository mensualiteRepository) {
        this.echeancierRepository = echeancierRepository;
        this.clientRepository = clientRepository;
        this.prestataireRepository = prestataireRepository;
        this.mensualiteRepository = mensualiteRepository;
    }

    @Override
    @Transactional
    public Echeancier creerEcheancier(Long clientId, Long prestataireId, double montantTotal, int nbMensualites) {
        if (nbMensualites <= 0) throw new BadRequestException("Nombre de mensualités invalide");
        Client client = clientRepository.findById(clientId)
                .orElseThrow(() -> new ResourceNotFoundException("Client non trouvé"));
        Prestataire prestataire = prestataireRepository.findById(prestataireId)
                .orElseThrow(() -> new ResourceNotFoundException("Prestataire non trouvé"));

        Echeancier e = new Echeancier();
        e.setClient(client);
        e.setPrestataire(prestataire);
        BigDecimal montantTotalBD = BigDecimal.valueOf(montantTotal).setScale(2, RoundingMode.HALF_UP);
        e.setMontantTotal(montantTotalBD);
        e.setNombreMensualites(nbMensualites);
        e.setDateCreation(LocalDate.now());
        e.setStatut(StatutEcheancier.EN_COURS);

        // Génération des mensualités
        List<Mensualite> mensualites = genererMensualites(e, montantTotalBD, nbMensualites);
        e.setMensualites(mensualites);

        // Persister (cascade de Mensualite via Echeancier) :
        Echeancier saved = echeancierRepository.save(e);
        // Si cascade non configuré pour JoinColumn (nous avons cascade ALL sur Echeancier côté entité),
        // enregistrez aussi les mensualites via repo si nécessaire. Ici, on sauvegarde par cascade.
        return saved;
    }

    private List<Mensualite> genererMensualites(Echeancier echeancier, BigDecimal montantTotal, int nbMensualites) {
        List<Mensualite> list = new ArrayList<>();
        // montant par mensualité = montantTotal / nbMensualites (arrondi)
        BigDecimal montantMens = montantTotal.divide(BigDecimal.valueOf(nbMensualites), 2, RoundingMode.HALF_UP);
        LocalDate cur = LocalDate.now().plusMonths(1); // première échéance dans 1 mois
        for (int i = 1; i <= nbMensualites; i++) {
            Mensualite m = new Mensualite();
            m.setNumero(i);
            m.setDateEcheance(cur);
            m.setMontant(montantMens);
            m.setStatut(StatutMensualite.EN_ATTENTE);
            m.setEcheancier(echeancier);
            list.add(m);
            cur = cur.plusMonths(1);
        }
        return list;
    }

    @Override
    @Transactional
    public Echeancier mettreAJourStatut(Long echeancierId) {
        Echeancier e = echeancierRepository.findById(echeancierId)
                .orElseThrow(() -> new ResourceNotFoundException("Echeancier non trouvé"));
        boolean allPaid = true;
        boolean anyDelay = false;
        List<Mensualite> mensualites = e.getMensualites();
        if (mensualites == null || mensualites.isEmpty()) {
            e.setStatut(StatutEcheancier.ANNULE);
            return echeancierRepository.save(e);
        }
        for (Mensualite m : mensualites) {
            if (m.getStatut() == null || !m.getStatut().name().equalsIgnoreCase("PAYEE")) {
                allPaid = false;
            }
            if (m.getStatut() != null && m.getStatut().name().equalsIgnoreCase("EN_RETARD")) {
                anyDelay = true;
            }
        }
        if (allPaid) e.setStatut(StatutEcheancier.TERMINE);
        else e.setStatut(StatutEcheancier.EN_COURS);
        // si anyDelay tu peux éventuellement ajouter champ de signalement
        return echeancierRepository.save(e);
    }

    @Override
    public Echeancier trouverParId(Long id) {
        return echeancierRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Echeancier non trouvé"));
    }

    @Override
    public List<Echeancier> trouverParPrestataire(Long prestataireId) {
        Prestataire prestataire = prestataireRepository.findById(prestataireId)
                .orElseThrow(() -> new ResourceNotFoundException("Prestataire non trouvé"));
        return echeancierRepository.findByPrestataire(prestataire);
    }

    @Override
    public List<Echeancier> rechercherParNomClient(String nom) {
        return echeancierRepository.findByClientNom(nom);
    }

    @Override
    @Transactional
    public Echeancier creerEcheancierParNomClient(
            String nomClient,
            Long prestataireId,
            double montantTotal,
            int nbMensualites) {

        Client client = clientRepository
                .findFirstByNomCompletIgnoreCase(nomClient)
                .orElseThrow(() ->
                        new ResourceNotFoundException("Client non trouvé : " + nomClient));

        return creerEcheancier(
                client.getId(),
                prestataireId,
                montantTotal,
                nbMensualites
        );
    }



}
