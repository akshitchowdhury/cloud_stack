package com.example.bTest.test0.controller;


import com.example.bTest.test0.model.Test;
import com.example.bTest.test0.service.TestService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/users")

public class TestController {

    private final TestService testService;

    public TestController(TestService testService) {
        this.testService = testService;
    }

    @CrossOrigin(origins = "http://localhost:5173/")
    @GetMapping
    public List<Test> getAllList()
    {
        return testService.getAllList();
    }

    @PostMapping("/createTest")
    public Test create(@RequestBody Test entity) {
        return testService.create(entity);
    }
}
