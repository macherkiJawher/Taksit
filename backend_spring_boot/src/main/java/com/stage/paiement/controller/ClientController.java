package com.stage.paiement.controller;

import com.stage.paiement.dto.ClientRequest;
import com.stage.paiement.entity.Client;
import com.stage.paiement.exception.ResourceNotFoundException;
import com.stage.paiement.service.ClientService;
import jakarta.validation.Valid;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/clients")
public class ClientController {

    private final ClientService clientService;

    public ClientController(ClientService clientService) {
        this.clientService = clientService;
    }

    @PostMapping
    public ResponseEntity<?> create(@Valid @RequestBody ClientRequest req) {
        Client c = new Client();

        return ResponseEntity.ok(clientService.creerClient(c));
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> get(@PathVariable Long id) {
        return clientService.trouverParId(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/{id}/score")
    public ResponseEntity<?> calculateScore(@PathVariable Long id) {
        double score = clientService.calculerScoreEligibilite(id);
        return ResponseEntity.ok(score);
    }

    @GetMapping("/search")
    public ResponseEntity<?> searchByName(@RequestParam String nom) {
        return ResponseEntity.ok(clientService.rechercherParNom(nom));
    }

    @GetMapping("/score-by-name")
    public ResponseEntity<?> getScoreByName(@RequestParam String nom) {

        Client client = clientService.rechercherParNom(nom).stream()
                .findFirst()
                .orElseThrow(() -> new ResourceNotFoundException("Client non trouvé"));

        double score = clientService.calculerScoreEligibilite(client.getId());

        return ResponseEntity.ok(score);
    }




}
