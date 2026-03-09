package com.stage.paiement.dto;

import com.stage.paiement.enums.Role;
import jakarta.validation.constraints.*;
import lombok.Getter;
import lombok.Setter;

@Getter @Setter
public class RegisterRequest {

    @NotBlank
    private String nomComplet;

    @Email
    @NotBlank
    private String email;

    @Size(min = 6)
    @NotBlank
    private String motDePasse;

    @NotBlank
    private String telephone;

    @NotNull
    private Role role; // CLIENT ou PRESTATAIRE

    // Données spécifiques Prestataire
    private String nomBoutique;
    private String adresseBoutique;
}
