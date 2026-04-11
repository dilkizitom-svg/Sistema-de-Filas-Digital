package com.bci.queue.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class HomeController {

    @GetMapping("/")
    public String home() {
        return "redirect:/gestor.html";
    }

    @GetMapping("/gestor")
    public String gestor() {
        return "redirect:/gestor.html";
    }

    @GetMapping("/atendente")
    public String atendente() {
        return "redirect:/index.html";
    }
}
