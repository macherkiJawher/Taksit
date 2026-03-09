package com.stage.paiement.entity;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.stage.paiement.enums.StatutMensualite;
import jakarta.persistence.*;
import lombok.*;

import java.math.BigDecimal;
import java.time.LocalDate;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Mensualite {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Integer numero;

    private LocalDate dateEcheance;

    private BigDecimal montant;

    @Enumerated(EnumType.STRING)
    private StatutMensualite statut;

    private LocalDate datePaiement;

    private String photoRecuPath;

    @ManyToOne
    @JoinColumn(name = "echeancier_id")
    @JsonBackReference
    private Echeancier echeancier;
}