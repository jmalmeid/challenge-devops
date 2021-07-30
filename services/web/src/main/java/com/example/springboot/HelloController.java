package com.example.springboot;

import java.net.InetAddress;
import java.lang.Exception;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

	@GetMapping("/")
	public String index() {
                String hostname = "none";
                try {
                   hostname = InetAddress.getLocalHost().getHostName();
                }
                catch(Exception e) {
                  e.printStackTrace();
                }
                
		return hostname + " - Greetings from Spring Boot!";
	}

}
