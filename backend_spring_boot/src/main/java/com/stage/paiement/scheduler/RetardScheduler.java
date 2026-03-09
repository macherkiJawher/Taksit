package com.stage.paiement.scheduler;

import com.stage.paiement.entity.Echeancier;
import com.stage.paiement.entity.Mensualite;
import com.stage.paiement.enums.StatutMensualite;
import com.stage.paiement.repository.EcheancierRepository;
import com.stage.paiement.repository.MensualiteRepository;
import com.stage.paiement.service.ClientService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

@Slf4j
@Component
@RequiredArgsConstructor
public class RetardScheduler {

    private final MensualiteRepository mensualiteRepository;
    private final EcheancierRepository echeancierRepository;
    private final ClientService clientService;

    // ✅ Tourne chaque jour à 8h00
    @Scheduled(cron = "0 0 8 * * *")
    @Transactional
    public void detecterRetards() {

        log.info("🔍 Vérification des mensualités en retard...");

        // Récupérer toutes les mensualités EN_ATTENTE dont la date est dépassée
        List<Mensualite> enRetard = mensualiteRepository
                .findByStatutAndDateEcheanceBefore(
                        StatutMensualite.EN_ATTENTE,
                        LocalDate.now()
                );

        if (enRetard.isEmpty()) {
            log.info("✅ Aucune mensualité en retard détectée.");
            return;
        }

        log.info("⚠️ {} mensualité(s) en retard détectée(s).", enRetard.size());

        // Passer chaque mensualité à EN_RETARD
        enRetard.forEach(m -> m.setStatut(StatutMensualite.EN_RETARD));
        mensualiteRepository.saveAll(enRetard);

        // Recalculer le score de chaque client concerné
        List<Long> clientIds = enRetard.stream()
                .map(m -> m.getEcheancier().getClient().getId())
                .distinct()
                .collect(Collectors.toList());

        clientIds.forEach(clientId -> {
            try {
                double nouveauScore = clientService.calculerScoreEligibilite(clientId);
                log.info("📊 Score client {} recalculé : {}", clientId, nouveauScore);
            } catch (Exception e) {
                log.error("❌ Erreur recalcul score client {}: {}", clientId, e.getMessage());
            }
        });

        log.info("✅ Détection des retards terminée.");
    }
}