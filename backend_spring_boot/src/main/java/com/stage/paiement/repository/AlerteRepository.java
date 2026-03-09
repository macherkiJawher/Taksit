package com.stage.paiement.repository;

import com.stage.paiement.entity.Alerte;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface AlerteRepository extends JpaRepository<Alerte, Long> {

    // Alertes non lues d'un client
    List<Alerte> findByClientIdAndLueFalseOrderByDateCreationDesc(Long clientId);

    // Toutes les alertes d'un client
    List<Alerte> findByClientIdOrderByDateCreationDesc(Long clientId);
}