package com.stage.paiement.entity;

import com.stage.paiement.enums.Role;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Inheritance(strategy = InheritanceType.JOINED)
public class Utilisateur {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private String nomComplet;

    @Column(unique = true)
    private String email;

    private String motDePasse;

    @Column(unique = true)
    private String telephone;

    @Enumerated(EnumType.STRING)
    private Role role;

    private LocalDateTime dateInscription;

    @Column(nullable = false)
    private boolean actif = true;
}