package com.stage.paiement.service;

import com.stage.paiement.entity.Echeancier;

import java.util.List;

public interface EcheancierService {

    Echeancier creerEcheancier(Long clientId, Long prestataireId,
                               double montantTotal, int nbMensualites);

    Echeancier mettreAJourStatut(Long echeancierId);

    Echeancier trouverParId(Long id);
    List<Echeancier> trouverParPrestataire(Long prestataireId);

    List<Echeancier> rechercherParNomClient(String nom);

    Echeancier creerEcheancierParNomClient(
            String nomClient,
            Long prestataireId,
            double montantTotal,
            int nbMensualites
    );



}
