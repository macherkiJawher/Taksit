package com.stage.paiement.controller;

import com.stage.paiement.dto.EcheancierRequest;
import com.stage.paiement.entity.Client;
import com.stage.paiement.entity.Echeancier;
import com.stage.paiement.entity.Prestataire;
import com.stage.paiement.entity.Utilisateur;
import com.stage.paiement.exception.ResourceNotFoundException;
import com.stage.paiement.repository.ClientRepository;
import com.stage.paiement.repository.EcheancierRepository;
import com.stage.paiement.service.EcheancierService;
import com.stage.paiement.service.UtilisateurService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/echeanciers")
public class EcheancierController {

    private final EcheancierService echeancierService;
    private final UtilisateurService utilisateurService;
    private final EcheancierRepository echeancierRepository;
    private final ClientRepository clientRepository;



    public EcheancierController(EcheancierService echeancierService,
                                UtilisateurService utilisateurService,
                                EcheancierRepository echeancierRepository,
                                ClientRepository clientRepository) {
        this.echeancierService = echeancierService;
        this.utilisateurService = utilisateurService;
        this.echeancierRepository = echeancierRepository;
        this.clientRepository = clientRepository;
    }

    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody EcheancierRequest req,
                                    Principal principal) {

        String email = principal.getName();

        Utilisateur user = utilisateurService.trouverParEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (!(user instanceof Prestataire)) {
            return ResponseEntity.status(403)
                    .body("Seul un prestataire peut créer un échéancier");
        }

        Prestataire prestataire = (Prestataire) user;

        Echeancier e = echeancierService.creerEcheancierParNomClient(
                req.getNomClient(),          // 🔥 NOM
                prestataire.getId(),
                req.getMontantTotal(),
                req.getNombreMensualites()
        );

        return ResponseEntity.ok(e);
    }


    @GetMapping("/{id}")
    public ResponseEntity<?> get(@PathVariable Long id) {
        return ResponseEntity.ok(echeancierService.trouverParId(id));
    }

    @PutMapping("/{id}/statut")
    public ResponseEntity<?> updateStatus(@PathVariable Long id) {
        return ResponseEntity.ok(echeancierService.mettreAJourStatut(id));
    }

    @GetMapping
    public ResponseEntity<?> getAllForPrestataire(Principal principal) {
        String email = principal.getName();

        Utilisateur user = utilisateurService.trouverParEmail(email)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

        if (!(user instanceof Prestataire)) {
            return ResponseEntity.status(403).body("Seul un prestataire peut voir ses échéanciers");
        }

        Prestataire prestataire = (Prestataire) user;

        // On récupère tous les échéanciers liés au prestataire
        List<Echeancier> echeanciers = echeancierService.trouverParPrestataire(prestataire.getId());

        return ResponseEntity.ok(echeanciers);
    }
    @GetMapping("/search")
    public ResponseEntity<?> searchByClientName(@RequestParam String nom) {
        return ResponseEntity.ok(
                echeancierService.rechercherParNomClient(nom)
        );
    }
    @GetMapping("/client/{clientId}")
    public ResponseEntity<?> getAllForClient(@PathVariable Long clientId) {
        Client client = clientRepository.findById(clientId)
                .orElseThrow(() -> new ResourceNotFoundException("Client non trouvé"));
        List<Echeancier> echeanciers = echeancierRepository.findByClient(client);
        return ResponseEntity.ok(echeanciers);
    }


}
