package com.stage.paiement.dto;

public class PrestataireStatsDto {

    private long totalEcheanciers;
    private long echeanciersEnCours;
    private long echeanciersTermines;
    private double montantTotal;
    private double montantPaye;

    public PrestataireStatsDto(
            long totalEcheanciers,
            long echeanciersEnCours,
            long echeanciersTermines,
            double montantTotal,
            double montantPaye
    ) {
        this.totalEcheanciers = totalEcheanciers;
        this.echeanciersEnCours = echeanciersEnCours;
        this.echeanciersTermines = echeanciersTermines;
        this.montantTotal = montantTotal;
        this.montantPaye = montantPaye;
    }

    public long getTotalEcheanciers() {
        return totalEcheanciers;
    }

    public long getEcheanciersEnCours() {
        return echeanciersEnCours;
    }

    public long getEcheanciersTermines() {
        return echeanciersTermines;
    }

    public double getMontantTotal() {
        return montantTotal;
    }

    public double getMontantPaye() {
        return montantPaye;
    }
}
