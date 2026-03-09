package com.stage.paiement.dto;

import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class EcheancierRequest {

    @NotNull
    private String nomClient;

    @Min(1)
    private double montantTotal;

    @Min(1)
    private int nombreMensualites;
}
