package com.stage.paiement.entity;

import com.fasterxml.jackson.annotation.JsonManagedReference;
import com.stage.paiement.enums.StatutEcheancier;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Echeancier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private BigDecimal montantTotal;

    private Integer nombreMensualites;

    private LocalDate dateCreation;

    @Enumerated(EnumType.STRING)
    private StatutEcheancier statut;

    @ManyToOne
    @JoinColumn(name = "client_id")
    private Client client;

    @ManyToOne
    @JoinColumn(name = "prestataire_id")
    private Prestataire prestataire;

    @OneToMany(mappedBy = "echeancier", cascade = CascadeType.ALL)
    @JsonManagedReference

    private List<Mensualite> mensualites;
}
