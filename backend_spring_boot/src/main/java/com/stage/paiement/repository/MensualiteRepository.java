package com.stage.paiement.repository;

import com.stage.paiement.entity.Mensualite;
import com.stage.paiement.entity.Echeancier;
import com.stage.paiement.enums.StatutMensualite;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface MensualiteRepository extends JpaRepository<Mensualite, Long> {
    List<Mensualite> findByStatutAndDateEcheanceBefore(
            StatutMensualite statut,
            LocalDate date
    );
    List<Mensualite> findByEcheancierClientId(Long clientId);
    List<Mensualite> findByEcheancier(Echeancier echeancier);
}
