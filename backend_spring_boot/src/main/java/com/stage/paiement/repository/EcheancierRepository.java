package com.stage.paiement.repository;

import com.stage.paiement.entity.Echeancier;
import com.stage.paiement.entity.Client;
import com.stage.paiement.entity.Prestataire;
import com.stage.paiement.enums.StatutEcheancier;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface EcheancierRepository extends JpaRepository<Echeancier, Long> {

    List<Echeancier> findByClient(Client client);

    List<Echeancier> findByPrestataire(Prestataire prestataire);
    List<Echeancier> findByPrestataireId(Long prestataireId);

    @Query("""
        SELECT e FROM Echeancier e
        WHERE LOWER(e.client.nomComplet) LIKE LOWER(CONCAT('%', :nom, '%'))
    """)
    List<Echeancier> findByClientNom(String nom);

    long countByPrestataireId(Long prestataireId);
    long countByPrestataireIdAndStatut(Long prestataireId, StatutEcheancier statut);

}
