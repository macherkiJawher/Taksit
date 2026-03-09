package com.stage.paiement.controller;

import com.stage.paiement.entity.Alerte;
import com.stage.paiement.entity.Mensualite;
import com.stage.paiement.entity.Utilisateur;
import com.stage.paiement.enums.StatutMensualite;
import com.stage.paiement.enums.TypeAlerte;
import com.stage.paiement.repository.AlerteRepository;
import com.stage.paiement.repository.MensualiteRepository;
import com.stage.paiement.service.UtilisateurService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/alertes")
@RequiredArgsConstructor
public class AlerteController {

    private final AlerteRepository alerteRepository;
    private final MensualiteRepository mensualiteRepository;
    private final UtilisateurService utilisateurService;

    // ✅ Récupérer toutes les alertes non lues
    // ✅ Retourner TOUTES les alertes (lues + non lues)
    @GetMapping("/mes-alertes")
    public ResponseEntity<?> getMesAlertes(Principal principal) {

        Utilisateur user = utilisateurService
                .trouverParEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        // ✅ Toutes les alertes (pas seulement non lues)
        List<Alerte> toutesAlertes = alerteRepository
                .findByClientIdOrderByDateCreationDesc(user.getId());

        List<Map<String, Object>> resultat = new java.util.ArrayList<>();

        // Alertes sauvegardées (paiements confirmés)
        toutesAlertes.forEach(a -> resultat.add(Map.of(
                "id", a.getId(),
                "type", a.getType().name(),
                "titre", a.getTitre(),
                "message", a.getMessage(),
                "lue", a.isLue(),
                "date", a.getDateCreation().toString()
        )));

        // Alertes dynamiques (retards + rappels)
        LocalDate today = LocalDate.now();
        LocalDate dans3Jours = today.plusDays(3);

        List<Mensualite> mensualites = mensualiteRepository
                .findByEcheancierClientId(user.getId());

        for (Mensualite m : mensualites) {
            if (m.getStatut() == StatutMensualite.EN_RETARD) {
                resultat.add(Map.of(
                        "type", "RETARD",
                        "titre", "⚠️ Mensualité en retard",
                        "message", "Mensualité n°" + m.getNumero()
                                + " de " + m.getMontant() + " DT est en retard !",
                        "lue", false,
                        "date", today.toString()
                ));
            } else if (m.getStatut() == StatutMensualite.EN_ATTENTE
                    && !m.getDateEcheance().isAfter(dans3Jours)
                    && !m.getDateEcheance().isBefore(today)) {
                resultat.add(Map.of(
                        "type", "RAPPEL",
                        "titre", "📅 Rappel",
                        "message", "Mensualité n°" + m.getNumero()
                                + " de " + m.getMontant()
                                + " DT due le " + m.getDateEcheance(),
                        "lue", false,
                        "date", today.toString()
                ));
            }
        }

        return ResponseEntity.ok(resultat);
    }

    // ✅ Compter seulement les non lues (pour le badge)
    @GetMapping("/count")
    public ResponseEntity<?> countNonLues(Principal principal) {
        Utilisateur user = utilisateurService
                .trouverParEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        long count = alerteRepository
                .findByClientIdAndLueFalseOrderByDateCreationDesc(user.getId())
                .size();

        return ResponseEntity.ok(Map.of("count", count));
    }

    // ✅ Marquer une alerte comme lue
    @PutMapping("/{id}/lue")
    public ResponseEntity<?> marquerLue(@PathVariable Long id) {
        Alerte alerte = alerteRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Alerte non trouvée"));
        alerte.setLue(true);
        alerteRepository.save(alerte);
        return ResponseEntity.ok(Map.of("message", "Alerte marquée comme lue"));
    }

    // ✅ Nombre d'alertes non lues (pour le badge)
    
}