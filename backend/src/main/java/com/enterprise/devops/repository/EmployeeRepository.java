package com.enterprise.devops.repository;

import com.enterprise.devops.model.entity.Employee;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    boolean existsByEmail(String email);

    List<Employee> findByDepartmentId(Long departmentId);
}
