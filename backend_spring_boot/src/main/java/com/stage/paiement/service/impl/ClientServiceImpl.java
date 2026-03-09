package com.stage.paiement.service.impl;

import com.stage.paiement.entity.Client;
import com.stage.paiement.entity.Echeancier;
import com.stage.paiement.entity.Mensualite;
import com.stage.paiement.exception.ResourceNotFoundException;
import com.stage.paiement.repository.ClientRepository;
import com.stage.paiement.repository.EcheancierRepository;
import com.stage.paiement.service.ClientService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class ClientServiceImpl implements ClientService {

    private final ClientRepository clientRepository;
    private final EcheancierRepository echeancierRepository;

    public ClientServiceImpl(ClientRepository clientRepository,
                             EcheancierRepository echeancierRepository) {
        this.clientRepository = clientRepository;
        this.echeancierRepository = echeancierRepository;
    }

    @Override
    @Transactional
    public Client creerClient(Client client) {
        // score initial 0.0 si null
        if (client.getScoreEligibilite() == null) {
            client.setScoreEligibilite(0.0);
        }
        return clientRepository.save(client);
    }

    @Override
    public java.util.Optional<Client> trouverParId(Long id) {
        return clientRepository.findById(id);
    }

    /**
     * Calcul de score simple :
     * - On parcourt tous les échéanciers du client
     * - On calcule le ratio de mensualités payées / total (0..1)
     * - Score = 20 (base) + 80 * ratio (résultat 20..100)
     * - Si aucun échéancier -> score par défaut 0
     */
    @Override
    @Transactional
    public double calculerScoreEligibilite(Long clientId) {
        Client client = clientRepository.findById(clientId)
                .orElseThrow(() -> new ResourceNotFoundException("Client non trouvé"));

        List<Echeancier> eches = echeancierRepository.findByClient(client);
        if (eches.isEmpty()) {
            client.setScoreEligibilite(0.0);
            return 0.0;
        }

        long totalMens = 0;
        long payees = 0;

        for (Echeancier e : eches) {
            if (e.getMensualites() != null) {
                totalMens += e.getMensualites().size();
                for (Mensualite m : e.getMensualites()) {
                    if (m.getStatut() != null &&
                            m.getStatut().name().equalsIgnoreCase("PAYEE")) {
                        payees++;
                    }
                }
            }
        }

        if (totalMens == 0) {
            client.setScoreEligibilite(0.0);
            return 0.0;
        }

        double ratio = (double) payees / totalMens;
        double score = 20.0 + 80.0 * ratio;

        score = Math.max(0, Math.min(100, score));

        client.setScoreEligibilite(score);
        clientRepository.save(client); // ✅ maintenant ça marche

        return score;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Client> rechercherParNom(String nom) {
        return clientRepository.findByNomCompletContainingIgnoreCase(nom);
    }



}
