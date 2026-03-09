package com.stage.paiement.controller;

import com.stage.paiement.entity.Mensualite;
import com.stage.paiement.repository.MensualiteRepository;
import com.stage.paiement.service.FileStorageService;
import com.stage.paiement.service.MensualiteService;
import com.stage.paiement.service.QrCodeService;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/mensualites")
public class MensualiteController {

    private final MensualiteService mensualiteService;
    private final FileStorageService fileStorageService;
    private final QrCodeService qrCodeService;
    private final MensualiteRepository mensualiteRepository;


    public MensualiteController(MensualiteService mensualiteService,
                                QrCodeService qrCodeService,
                                MensualiteRepository mensualiteRepository,
                                FileStorageService fileStorageService) {
        this.mensualiteService = mensualiteService;
        this.fileStorageService = fileStorageService;
        this.mensualiteRepository = mensualiteRepository;
        this.qrCodeService = qrCodeService;
    }

    // ✅ Ancien endpoint (sans photo) — garder pour compatibilité
    @PutMapping("/{id}/payer")
    public ResponseEntity<?> pay(@PathVariable Long id) {
        return ResponseEntity.ok(
                mensualiteService.marquerCommePayee(id, null)
        );
    }

    // ✅ Nouveau endpoint (avec photo du reçu)
    @PutMapping("/{id}/payer-avec-recu")
    public ResponseEntity<?> payAvecRecu(
            @PathVariable Long id,
            @RequestParam(value = "photo", required = false) MultipartFile photo) {

        String photoPath = null;

        if (photo != null && !photo.isEmpty()) {
            try {
                photoPath = fileStorageService.sauvegarderRecu(photo);
            } catch (Exception e) {
                return ResponseEntity.status(500)
                        .body("Erreur lors de l'upload du reçu");
            }
        }

        return ResponseEntity.ok(
                mensualiteService.marquerCommePayee(id, photoPath)
        );
    }

    // ✅ Voir l'image du reçu
    @GetMapping("/{id}/recu")
    public ResponseEntity<?> getRecu(@PathVariable Long id) {
        var mensualite = mensualiteService.trouverParId(id);
        if (mensualite.getPhotoRecuPath() == null) {
            return ResponseEntity.notFound().build();
        }
        return ResponseEntity.ok(
                java.util.Map.of("path", mensualite.getPhotoRecuPath())
        );
    }

    @GetMapping("/{id}")
    public ResponseEntity<?> get(@PathVariable Long id) {
        return ResponseEntity.ok(mensualiteService.trouverParId(id));
    }

    @GetMapping("/{id}/qrcode")
    public ResponseEntity<byte[]> getQrCode(@PathVariable Long id) {
        try {
            Mensualite mensualite = mensualiteRepository.findById(id)
                    .orElseThrow(() -> new RuntimeException("Mensualité introuvable"));

            byte[] qrCode = qrCodeService.genererQrCode(mensualite);

            return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_PNG)
                    .body(qrCode);

        } catch (Exception e) {
            return ResponseEntity.status(500).build();
        }
    }
}