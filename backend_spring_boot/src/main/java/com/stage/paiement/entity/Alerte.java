package com.stage.paiement.entity;

import com.stage.paiement.enums.TypeAlerte;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
public class Alerte {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne
    @JoinColumn(name = "client_id")
    private Utilisateur client;

    private String titre;

    private String message;

    @Enumerated(EnumType.STRING)
    private TypeAlerte type;

    private boolean lue = false;

    private LocalDateTime dateCreation = LocalDateTime.now();

    // ✅ Constructeur rapide
    public Alerte(Utilisateur client, String titre,
                  String message, TypeAlerte type) {
        this.client = client;
        this.titre = titre;
        this.message = message;
        this.type = type;
        this.dateCreation = LocalDateTime.now();
        this.lue = false;
    }
}