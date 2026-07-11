package com.enterprise.devops.service.impl;

import com.enterprise.devops.dto.DepartmentDTO;
import com.enterprise.devops.exception.ResourceNotFoundException;
import com.enterprise.devops.model.entity.Department;
import com.enterprise.devops.repository.DepartmentRepository;
import com.enterprise.devops.service.DepartmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class DepartmentServiceImpl implements DepartmentService {

    private final DepartmentRepository departmentRepository;

    @Override
    @Transactional(readOnly = true)
    public List<DepartmentDTO> getAllDepartments() {
        return departmentRepository.findAll()
                .stream()
                .map(this::toDTO)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public DepartmentDTO getDepartmentById(Long id) {
        Department department = departmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Department", id));
        return toDTO(department);
    }

    @Override
    public DepartmentDTO createDepartment(DepartmentDTO departmentDTO) {
        if (departmentRepository.existsByCode(departmentDTO.getCode())) {
            throw new IllegalArgumentException("Department code already exists: " + departmentDTO.getCode());
        }
        Department department = toEntity(departmentDTO);
        Department saved = departmentRepository.save(department);
        return toDTO(saved);
    }

    @Override
    public DepartmentDTO updateDepartment(Long id, DepartmentDTO departmentDTO) {
        Department existing = departmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Department", id));

        existing.setName(departmentDTO.getName());
        existing.setCode(departmentDTO.getCode());
        existing.setLocation(departmentDTO.getLocation());

        return toDTO(departmentRepository.save(existing));
    }

    @Override
    public void deleteDepartment(Long id) {
        if (!departmentRepository.existsById(id)) {
            throw new ResourceNotFoundException("Department", id);
        }
        departmentRepository.deleteById(id);
    }

    private DepartmentDTO toDTO(Department department) {
        return DepartmentDTO.builder()
                .id(department.getId())
                .name(department.getName())
                .code(department.getCode())
                .location(department.getLocation())
                .build();
    }

    private Department toEntity(DepartmentDTO dto) {
        return Department.builder()
                .name(dto.getName())
                .code(dto.getCode())
                .location(dto.getLocation())
                .build();
    }
}
