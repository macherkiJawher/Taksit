package com.stage.paiement.service.impl;

import com.stage.paiement.dto.RegisterRequest;
import com.stage.paiement.dto.RegisterResponse;
import com.stage.paiement.entity.Client;
import com.stage.paiement.entity.Prestataire;
import com.stage.paiement.entity.Utilisateur;
import com.stage.paiement.enums.*;
import com.stage.paiement.repository.*;
import com.stage.paiement.service.AuthService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UtilisateurRepository utilisateurRepository;
    private final ClientRepository clientRepository;
    private final PrestataireRepository prestataireRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public RegisterResponse register(RegisterRequest req) {

        if (utilisateurRepository.existsByEmail(req.getEmail())) {
            throw new RuntimeException("Cet email est déjà utilisé.");
        }

        Utilisateur user;

        if (req.getRole() == Role.CLIENT) {
            Client c = new Client();
            c.setScoreEligibilite(0.0);
            user = c;
        }
        else if (req.getRole() == Role.PRESTATAIRE) {
            Prestataire p = new Prestataire();
            p.setNomBoutique(req.getNomBoutique());
            p.setAdresseBoutique(req.getAdresseBoutique());
            user = p;
        }
        else {
            throw new RuntimeException("Rôle non supporté.");
        }

        // Remplir les données communes
        user.setNomComplet(req.getNomComplet());
        user.setEmail(req.getEmail());
        user.setTelephone(req.getTelephone());
        user.setRole(req.getRole());
        user.setMotDePasse(passwordEncoder.encode(req.getMotDePasse()));
        user.setDateInscription(LocalDateTime.now());

        Utilisateur saved = utilisateurRepository.save(user);

        return new RegisterResponse(
                "Inscription réussie",
                saved.getId(),
                saved.getRole().name()
        );
    }
}
