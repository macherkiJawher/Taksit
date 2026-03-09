package com.stage.paiement.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class ClientRequest {

    @NotBlank
    private String adresse;

    // éventuellement autres champs d’inscription

    // getters/setters
}
