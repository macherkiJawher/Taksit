package com.stage.paiement.service;

import com.stage.paiement.dto.PrestataireStatsDto;
import com.stage.paiement.entity.Prestataire;

import java.util.Optional;

public interface PrestataireService {

    Prestataire creerPrestataire(Prestataire prestataire);

    Optional<Prestataire> trouverParId(Long id);

    Optional<Prestataire> trouverParEmail(String email);
    PrestataireStatsDto getStats(Long prestataireId);


}
