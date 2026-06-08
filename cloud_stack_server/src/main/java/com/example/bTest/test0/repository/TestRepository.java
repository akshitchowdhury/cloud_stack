package com.example.bTest.test0.repository;

import com.example.bTest.test0.model.Test;
import org.springframework.data.jpa.repository.JpaRepository;

public interface TestRepository extends JpaRepository<Test, Integer> {

}
