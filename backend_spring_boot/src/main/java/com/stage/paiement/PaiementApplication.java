package com.stage.paiement;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableScheduling;

@SpringBootApplication
@EnableScheduling
public class PaiementApplication {

	public static void main(String[] args) {
		SpringApplication.run(PaiementApplication.class, args);
	}

}
