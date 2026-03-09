package com.stage.paiement.repository;

import com.stage.paiement.entity.Prestataire;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface PrestataireRepository extends JpaRepository<Prestataire, Long> {
    Optional<Prestataire> findByEmail(String email);

}
