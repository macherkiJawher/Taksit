package com.stage.paiement.service.impl;

import com.stage.paiement.entity.Utilisateur;
import com.stage.paiement.exception.BadRequestException;
import com.stage.paiement.repository.UtilisateurRepository;
import com.stage.paiement.service.UtilisateurService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class UtilisateurServiceImpl implements UtilisateurService {

    private final UtilisateurRepository utilisateurRepository;
    private final PasswordEncoder passwordEncoder;

    public UtilisateurServiceImpl(UtilisateurRepository utilisateurRepository,
                                  PasswordEncoder passwordEncoder) {
        this.utilisateurRepository = utilisateurRepository;
        this.passwordEncoder = passwordEncoder;
    }

    @Override
    @Transactional
    public Utilisateur inscription(Utilisateur utilisateur) {
        if (utilisateur.getEmail() != null &&
                utilisateurRepository.existsByEmail(utilisateur.getEmail())) {
            throw new BadRequestException("Email déjà utilisé");
        }
        if (utilisateur.getTelephone() != null &&
                utilisateurRepository.existsByTelephone(utilisateur.getTelephone())) {
            throw new BadRequestException("Téléphone déjà utilisé");
        }
        utilisateur.setMotDePasse(
                passwordEncoder.encode(utilisateur.getMotDePasse()));
        return utilisateurRepository.save(utilisateur);
    }

    @Override
    public Optional<Utilisateur> authentification(String email, String motDePasse) {
        Optional<Utilisateur> opt = utilisateurRepository.findByEmail(email);
        if (opt.isPresent()) {
            Utilisateur u = opt.get();

            // ✅ Vérifier si compte désactivé
            if (!u.isActif()) {
                throw new RuntimeException("Compte désactivé. Contactez l'administrateur.");
            }

            if (passwordEncoder.matches(motDePasse, u.getMotDePasse())) {
                return Optional.of(u);
            }
        }
        return Optional.empty();
    }

    @Override
    public Optional<Utilisateur> trouverParId(Long id) {
        return utilisateurRepository.findById(id);
    }

    @Override
    public Optional<Utilisateur> trouverParEmail(String email) {
        return utilisateurRepository.findByEmail(email);
    }
}