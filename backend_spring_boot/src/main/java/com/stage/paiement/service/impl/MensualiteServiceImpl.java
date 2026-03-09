package com.stage.paiement.service.impl;

import com.stage.paiement.entity.Alerte;
import com.stage.paiement.entity.Echeancier;
import com.stage.paiement.entity.Mensualite;
import com.stage.paiement.enums.StatutMensualite;
import com.stage.paiement.enums.TypeAlerte;
import com.stage.paiement.exception.ResourceNotFoundException;
import com.stage.paiement.repository.AlerteRepository;
import com.stage.paiement.repository.EcheancierRepository;
import com.stage.paiement.repository.MensualiteRepository;
import com.stage.paiement.service.ClientService;
import com.stage.paiement.service.MensualiteService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;

@Service
public class MensualiteServiceImpl implements MensualiteService {

    private final MensualiteRepository mensualiteRepository;
    private final EcheancierRepository echeancierRepository;
    private final ClientService clientService;
    private final AlerteRepository alerteRepository;

    public MensualiteServiceImpl(MensualiteRepository mensualiteRepository,
                                 EcheancierRepository echeancierRepository,
                                 ClientService clientService,
                                 AlerteRepository alerteRepository) {
        this.mensualiteRepository = mensualiteRepository;
        this.echeancierRepository = echeancierRepository;
        this.clientService = clientService;
        this.alerteRepository = alerteRepository;
    }

    @Override
    @Transactional
    public Mensualite marquerCommePayee(Long mensualiteId, String photoRecuPath) {

        Mensualite m = mensualiteRepository.findById(mensualiteId)
                .orElseThrow(() -> new ResourceNotFoundException("Mensualité non trouvée"));

        // 1️⃣ Marquer payée
        m.setStatut(StatutMensualite.PAYEE);
        m.setDatePaiement(LocalDate.now());
        if (photoRecuPath != null) {
            m.setPhotoRecuPath(photoRecuPath);
        }
        Mensualite saved = mensualiteRepository.save(m);

        // 2️⃣ Mettre à jour statut échéancier
        Echeancier e = m.getEcheancier();
        if (e != null) {
            boolean allPaid = e.getMensualites().stream()
                    .allMatch(mm -> mm.getStatut() == StatutMensualite.PAYEE);

            if (allPaid) {
                e.setStatut(com.stage.paiement.enums.StatutEcheancier.TERMINE);
            } else {
                e.setStatut(com.stage.paiement.enums.StatutEcheancier.EN_COURS);
            }
            echeancierRepository.save(e);

            // 3️⃣ Recalcul score
            clientService.calculerScoreEligibilite(e.getClient().getId());

            // 4️⃣ ✅ Sauvegarder l'alerte en base pour le client
            sauvegarderAlertePaiement(m, e, allPaid);
        }

        return saved;
    }

    private void sauvegarderAlertePaiement(Mensualite m, Echeancier e, boolean allPaid) {
        // Si tout est payé → message spécial
        if (allPaid) {
            alerteRepository.save(new Alerte(
                    e.getClient(),
                    "🎉 Crédit terminé !",
                    "Félicitations ! Votre crédit #" + e.getId() + " est entièrement remboursé.",
                    TypeAlerte.PAIEMENT
            ));
        } else {
            alerteRepository.save(new Alerte(
                    e.getClient(),
                    "✅ Paiement confirmé",
                    "Votre mensualité n°" + m.getNumero()
                            + " de " + m.getMontant() + " DT a été validée par le prestataire.",
                    TypeAlerte.PAIEMENT
            ));
        }
    }

    @Override
    public Mensualite trouverParId(Long id) {
        return mensualiteRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Mensualité non trouvée"));
    }
}