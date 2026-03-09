package com.stage.paiement.controller;

import com.stage.paiement.dto.PrestataireRequest;
import com.stage.paiement.dto.PrestataireStatsDto;
import com.stage.paiement.entity.Prestataire;
import com.stage.paiement.service.PrestataireService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;

@RestController
@RequestMapping("/api/prestataires")
public class PrestataireController {

    private final PrestataireService prestataireService;

    public PrestataireController(PrestataireService prestataireService) {
        this.prestataireService = prestataireService;
    }

    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody PrestataireRequest req) {
        Prestataire p = new Prestataire();
        p.setSociete(req.getSociete());
        return ResponseEntity.ok(prestataireService.creerPrestataire(p));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> get(@PathVariable Long id) {
        return prestataireService.trouverParId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/me")
    public ResponseEntity<?> getMe(Principal principal) {

        String email = principal.getName();

        Prestataire prestataire = prestataireService
                .trouverParEmail(email)
                .orElseThrow(() -> new RuntimeException("Prestataire non trouvé"));

        return ResponseEntity.ok(prestataire);
    }

    @GetMapping("/{id}/stats")
    public ResponseEntity<PrestataireStatsDto> getStats(@PathVariable Long id) {

        PrestataireStatsDto stats = prestataireService.getStats(id);

        return ResponseEntity.ok(stats);
    }

}
