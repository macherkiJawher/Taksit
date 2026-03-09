package com.stage.paiement.service;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.qrcode.QRCodeWriter;
import com.stage.paiement.entity.Mensualite;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;
import java.util.Locale;
import java.util.Map;

@Service
public class QrCodeService {

    public byte[] genererQrCode(Mensualite mensualite) throws Exception {

        Map<String, Object> data = new HashMap<>();
        data.put("mensualiteId", mensualite.getId());
        data.put("clientNom", mensualite.getEcheancier()
                .getClient().getNomComplet());

        // ✅ Forcer le point décimal avec Locale.US
        String montantStr = String.format(Locale.US, "%.2f",
                mensualite.getMontant());
        data.put("montant", Double.parseDouble(montantStr));

        data.put("dateEcheance", mensualite.getDateEcheance().toString());
        data.put("echeancierId", mensualite.getEcheancier().getId());

        ObjectMapper objectMapper = new ObjectMapper();
        String json = objectMapper.writeValueAsString(data);

        // ✅ Vérifier dans les logs
        System.out.println("✅ QR Code JSON : " + json);

        QRCodeWriter writer = new QRCodeWriter();
        BitMatrix bitMatrix = writer.encode(
                json, BarcodeFormat.QR_CODE, 300, 300
        );

        ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
        MatrixToImageWriter.writeToStream(bitMatrix, "PNG", outputStream);
        return outputStream.toByteArray();
    }
}