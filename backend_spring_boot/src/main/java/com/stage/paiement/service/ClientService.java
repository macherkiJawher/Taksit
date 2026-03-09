package com.stage.paiement.service;

import com.stage.paiement.entity.Client;

import java.util.List;
import java.util.Optional;

public interface ClientService {

    Client creerClient(Client client);

    Optional<Client> trouverParId(Long id);

    double calculerScoreEligibilite(Long clientId);

    List<Client> rechercherParNom(String nom);

}
