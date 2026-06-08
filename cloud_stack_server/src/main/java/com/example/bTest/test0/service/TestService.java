package com.example.bTest.test0.service;

import com.example.bTest.test0.model.Test;
import com.example.bTest.test0.repository.TestRepository;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TestService {
private final TestRepository testRepository;
//added
public TestService(TestRepository testRepository) {
	this.testRepository = testRepository;
}

public Test create(Test entity) {
    return testRepository.save(entity);
}

public List<Test> getAllList() {
	return testRepository.findAll();
}



}
