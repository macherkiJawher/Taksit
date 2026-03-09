package com.stage.paiement.controller;

import com.stage.paiement.dto.AuthRequest;
import com.stage.paiement.dto.RegisterRequest;
import com.stage.paiement.dto.RegisterResponse;
import com.stage.paiement.entity.Utilisateur;
import com.stage.paiement.security.JwtUtil;
import com.stage.paiement.service.AuthService;
import com.stage.paiement.service.UtilisateurService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
@RequiredArgsConstructor
public class AuthController {

    private final UtilisateurService utilisateurService;
    private final AuthService authService;
    private final JwtUtil jwtUtil;

    @PostMapping("/register")
    public RegisterResponse register(@Valid @RequestBody RegisterRequest request) {
        return authService.register(request);
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, Object>> login(
            @RequestBody @Valid AuthRequest req) {

        try {
            Optional<Utilisateur> optUser =
                    utilisateurService.authentification(
                            req.getEmail(),
                            req.getMotDePasse()
                    );

            if (optUser.isEmpty()) {
                return ResponseEntity.status(401)
                        .body(Map.of("error", "Email ou mot de passe incorrect"));
            }

            Utilisateur u = optUser.get();

            String token = jwtUtil.generateToken(
                    u.getEmail(),
                    u.getRole().name()
            );

            Map<String, Object> response = new HashMap<>();
            response.put("id", u.getId());
            response.put("role", u.getRole().name());
            response.put("token", token);

            return ResponseEntity.ok(response);

        } catch (RuntimeException e) {
            // ✅ Capturer "Compte désactivé" et retourner 403
            if (e.getMessage() != null &&
                    e.getMessage().contains("désactivé")) {
                return ResponseEntity.status(403)
                        .body(Map.of("error", e.getMessage()));
            }
            return ResponseEntity.status(401)
                    .body(Map.of("error", "Email ou mot de passe incorrect"));
        }
    }

    // ✅ Déplacer hors de /api/auth
    @GetMapping("/test/hash")
    public String hash() {
        return new org.springframework.security.crypto.bcrypt
                .BCryptPasswordEncoder().encode("admin123");
    }
}
