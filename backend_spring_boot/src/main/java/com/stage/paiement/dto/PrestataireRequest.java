package com.stage.paiement.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PrestataireRequest {
    @NotBlank
    private String societe;

    // getters/setters
}
