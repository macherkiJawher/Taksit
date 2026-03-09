package com.stage.paiement.service;

import com.stage.paiement.entity.Utilisateur;

import java.util.Optional;

public interface UtilisateurService {

    Utilisateur inscription(Utilisateur utilisateur);

    Optional<Utilisateur> authentification(String email, String motDePasse);

    Optional<Utilisateur> trouverParId(Long id);

    Optional<Utilisateur> trouverParEmail(String email);
}
