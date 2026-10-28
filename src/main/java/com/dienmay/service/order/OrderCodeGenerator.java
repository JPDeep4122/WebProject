package com.dienmay.service.order;

import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.Locale;

import org.springframework.stereotype.Component;

@Component
public class OrderCodeGenerator {

    private static final SecureRandom RANDOM = new SecureRandom();

    private static final ZoneId ZONE =
            ZoneId.of("Asia/Ho_Chi_Minh");

    public String nextCandidate() {
        String date = LocalDate.now(ZONE)
                .format(DateTimeFormatter.BASIC_ISO_DATE);

        String suffix = String.format(
                Locale.ROOT,
                "%06d",
                RANDOM.nextInt(1_000_000));

        return date + "-" + suffix;
    }
}