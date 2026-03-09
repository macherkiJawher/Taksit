package com.stage.paiement.service;

import com.stage.paiement.entity.Mensualite;

public interface MensualiteService {

    Mensualite marquerCommePayee(Long mensualiteId, String photoRecuPath);

    Mensualite trouverParId(Long id);
}
