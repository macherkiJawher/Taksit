package com.stage.paiement.controller;

import com.stage.paiement.entity.*;
import com.stage.paiement.enums.Role;
import com.stage.paiement.enums.StatutEcheancier;
import com.stage.paiement.enums.StatutMensualite;
import com.stage.paiement.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;
import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/admin")
@RequiredArgsConstructor
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final UtilisateurRepository utilisateurRepository;
    private final EcheancierRepository echeancierRepository;
    private final MensualiteRepository mensualiteRepository;

    // ✅ Stats globales
    @GetMapping("/stats")
    public ResponseEntity<?> getStats() {
        long totalClients = utilisateurRepository
                .findAll().stream()
                .filter(u -> u.getRole() == Role.CLIENT)
                .count();

        long totalPrestataires = utilisateurRepository
                .findAll().stream()
                .filter(u -> u.getRole() == Role.PRESTATAIRE)
                .count();

        long totalEcheanciers = echeancierRepository.count();

        long echeancierEnCours = echeancierRepository
                .findAll().stream()
                .filter(e -> e.getStatut() == StatutEcheancier.EN_COURS)
                .count();

        long echeancierTermines = echeancierRepository
                .findAll().stream()
                .filter(e -> e.getStatut() == StatutEcheancier.TERMINE)
                .count();

        // ✅ Fix BigDecimal → utiliser reduce au lieu de mapToDouble
        BigDecimal montantTotal = echeancierRepository
                .findAll().stream()
                .map(Echeancier::getMontantTotal)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        BigDecimal montantRecouvre = mensualiteRepository
                .findAll().stream()
                .filter(m -> m.getStatut() == StatutMensualite.PAYEE)
                .map(Mensualite::getMontant)
                .filter(Objects::nonNull)
                .reduce(BigDecimal.ZERO, BigDecimal::add);

        long mensualitesEnRetard = mensualiteRepository
                .findAll().stream()
                .filter(m -> m.getStatut() == StatutMensualite.EN_RETARD)
                .count();

        return ResponseEntity.ok(Map.of(
                "totalClients", totalClients,
                "totalPrestataires", totalPrestataires,
                "totalEcheanciers", totalEcheanciers,
                "echeancierEnCours", echeancierEnCours,
                "echeancierTermines", echeancierTermines,
                "montantTotal", montantTotal,           // ✅ BigDecimal
                "montantRecouvre", montantRecouvre,     // ✅ BigDecimal
                "mensualitesEnRetard", mensualitesEnRetard
        ));
    }

    // ✅ Liste tous les utilisateurs
    @GetMapping("/utilisateurs")
    public ResponseEntity<?> getUtilisateurs() {
        List<Map<String, Object>> result = utilisateurRepository
                .findAll().stream()
                .filter(u -> u.getRole() != Role.ADMIN)
                .map(u -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", u.getId());
                    map.put("nomComplet", u.getNomComplet());
                    map.put("email", u.getEmail());
                    map.put("role", u.getRole().name());
                    map.put("actif", u.isActif());
                    if (u instanceof Client c) {
                        map.put("scoreEligibilite", c.getScoreEligibilite());
                    }
                    if (u instanceof Prestataire p) {
                        map.put("nomBoutique", p.getNomBoutique());
                    }
                    return map;
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }

    // ✅ Activer / Désactiver un utilisateur
    @PutMapping("/utilisateurs/{id}/toggle")
    public ResponseEntity<?> toggleActif(@PathVariable Long id) {
        Utilisateur u = utilisateurRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));
        u.setActif(!u.isActif());
        utilisateurRepository.save(u);
        return ResponseEntity.ok(Map.of(
                "message", u.isActif() ? "Compte activé" : "Compte désactivé",
                "actif", u.isActif()
        ));
    }

    // ✅ Liste tous les échéanciers
    @GetMapping("/echeanciers")
    public ResponseEntity<?> getEcheanciers() {
        List<Map<String, Object>> result = echeancierRepository
                .findAll().stream()
                .map(e -> {
                    Map<String, Object> map = new HashMap<>();
                    map.put("id", e.getId());
                    map.put("montantTotal", e.getMontantTotal()); // ✅ BigDecimal sérialisé automatiquement
                    map.put("nombreMensualites", e.getNombreMensualites());
                    map.put("statut", e.getStatut().name());
                    map.put("dateCreation", e.getDateCreation().toString());
                    map.put("clientNom", e.getClient().getNomComplet());
                    map.put("prestataireNom", e.getPrestataire().getNomBoutique());

                    long nbPayees = e.getMensualites().stream()
                            .filter(m -> m.getStatut() == StatutMensualite.PAYEE)
                            .count();
                    map.put("mensualitesPayees", nbPayees);
                    map.put("mensualitesTotal", e.getMensualites().size());
                    return map;
                })
                .collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }

    // ✅ Stats par mois (pour graphique)
    @GetMapping("/stats/par-mois")
    public ResponseEntity<?> getStatsParMois() {
        Map<String, Long> parMois = new LinkedHashMap<>();

        echeancierRepository.findAll().forEach(e -> {
            String mois = e.getDateCreation().getYear() + "-"
                    + String.format("%02d", e.getDateCreation().getMonthValue());
            parMois.merge(mois, 1L, Long::sum);
        });

        List<Map<String, Object>> result = parMois.entrySet().stream()
                .sorted(Map.Entry.comparingByKey())
                .map(entry -> Map.<String, Object>of(
                        "mois", entry.getKey(),
                        "nombre", entry.getValue()
                ))
                .collect(Collectors.toList());

        return ResponseEntity.ok(result);
    }
}