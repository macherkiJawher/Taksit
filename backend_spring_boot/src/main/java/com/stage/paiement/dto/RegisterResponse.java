package com.stage.paiement.dto;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public class RegisterResponse {
    private String message;
    private Long utilisateurId;
    private String role;
}
