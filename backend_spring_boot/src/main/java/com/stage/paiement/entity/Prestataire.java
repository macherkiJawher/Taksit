package com.stage.paiement.entity;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@NoArgsConstructor
@Entity
public class Prestataire extends Utilisateur {

    private String nomBoutique;
    private String adresseBoutique;
    private String societe;

    @OneToMany(mappedBy = "prestataire")
    @JsonIgnore
    private List<Echeancier> echeanciersAccordes;
}