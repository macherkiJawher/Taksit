package com.stage.paiement.service;

import com.stage.paiement.dto.RegisterRequest;
import com.stage.paiement.dto.RegisterResponse;

public interface AuthService {
    RegisterResponse register(RegisterRequest request);
}
