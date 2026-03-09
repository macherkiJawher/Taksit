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
public class Client extends Utilisateur {


    private Double scoreEligibilite;

    @OneToMany(mappedBy = "client")
    @JsonIgnore
    private List<Echeancier> echeanciers;
}