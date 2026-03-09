package com.stage.paiement.dto;

import com.stage.paiement.enums.Role;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter

public class AuthResponse {
    private Long id;
    private Role role;
    private String message;

    public AuthResponse(Long id, Role role, String message) {
        this.id = id;
        this.role = role;
        this.message = message;
    }

    // getters
}
