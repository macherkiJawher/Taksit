package com.stage.paiement.service.impl;

import com.stage.paiement.dto.PrestataireStatsDto;
import com.stage.paiement.entity.Echeancier;
import com.stage.paiement.entity.Mensualite;
import com.stage.paiement.entity.Prestataire;
import com.stage.paiement.enums.StatutEcheancier;
import com.stage.paiement.enums.StatutMensualite;
import com.stage.paiement.repository.EcheancierRepository;
import com.stage.paiement.repository.PrestataireRepository;
import com.stage.paiement.service.PrestataireService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Objects;
import java.util.Optional;

@Service
@Transactional
public class PrestataireServiceImpl implements PrestataireService {

    private final PrestataireRepository prestataireRepository;
    private final EcheancierRepository echeancierRepository;

    public PrestataireServiceImpl(
            PrestataireRepository prestataireRepository,
            EcheancierRepository echeancierRepository
    ) {
        this.prestataireRepository = prestataireRepository;
        this.echeancierRepository = echeancierRepository;
    }

    @Override
    public Prestataire creerPrestataire(Prestataire prestataire) {
        return prestataireRepository.save(prestataire);
    }

    @Override
    public Optional<Prestataire> trouverParId(Long id) {
        return prestataireRepository.findById(id);
    }

    @Override
    public Optional<Prestataire> trouverParEmail(String email) {
        return prestataireRepository.findByEmail(email);
    }

    @Override
    public PrestataireStatsDto getStats(Long prestataireId) {

        long total = echeancierRepository.countByPrestataireId(prestataireId);

        long enCours = echeancierRepository.countByPrestataireIdAndStatut(
                prestataireId,
                StatutEcheancier.EN_COURS
        );

        long termine = echeancierRepository.countByPrestataireIdAndStatut(
                prestataireId,
                StatutEcheancier.TERMINE
        );

        List<Echeancier> echeanciers =
                echeancierRepository.findByPrestataireId(prestataireId);

        double montantTotal = echeanciers.stream()
                .map(Echeancier::getMontantTotal)   // BigDecimal
                .filter(Objects::nonNull)
                .mapToDouble(BigDecimal::doubleValue)
                .sum();


        double montantPaye = echeanciers.stream()
                .flatMap(e -> e.getMensualites().stream())
                .filter(m -> m.getStatut() == StatutMensualite.PAYEE)
                .map(Mensualite::getMontant)   // BigDecimal
                .filter(Objects::nonNull)
                .mapToDouble(BigDecimal::doubleValue)
                .sum();


        return new PrestataireStatsDto(
                total,
                enCours,
                termine,
                montantTotal,
                montantPaye
        );
    }
}
