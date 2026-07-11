package com.enterprise.devops.service.impl;

import com.enterprise.devops.dto.ProjectDTO;
import com.enterprise.devops.exception.ResourceNotFoundException;
import com.enterprise.devops.model.entity.Department;
import com.enterprise.devops.model.entity.Project;
import com.enterprise.devops.repository.DepartmentRepository;
import com.enterprise.devops.repository.ProjectRepository;
import com.enterprise.devops.service.ProjectService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@RequiredArgsConstructor
@Transactional
public class ProjectServiceImpl implements ProjectService {

    private final ProjectRepository projectRepository;
    private final DepartmentRepository departmentRepository;

    @Override
    @Transactional(readOnly = true)
    public List<ProjectDTO> getAllProjects() {
        return projectRepository.findAll()
                .stream()
                .map(this::toDTO)
                .toList();
    }

    @Override
    @Transactional(readOnly = true)
    public ProjectDTO getProjectById(Long id) {
        Project project = projectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Project", id));
        return toDTO(project);
    }

    @Override
    public ProjectDTO createProject(ProjectDTO projectDTO) {
        Department department = departmentRepository.findById(projectDTO.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Department", projectDTO.getDepartmentId()));

        Project project = toEntity(projectDTO, department);
        Project saved = projectRepository.save(project);
        return toDTO(saved);
    }

    @Override
    public ProjectDTO updateProject(Long id, ProjectDTO projectDTO) {
        Project existing = projectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Project", id));

        Department department = departmentRepository.findById(projectDTO.getDepartmentId())
                .orElseThrow(() -> new ResourceNotFoundException("Department", projectDTO.getDepartmentId()));

        existing.setName(projectDTO.getName());
        existing.setDescription(projectDTO.getDescription());
        existing.setStatus(projectDTO.getStatus());
        existing.setStartDate(projectDTO.getStartDate());
        existing.setEndDate(projectDTO.getEndDate());
        existing.setDepartment(department);

        return toDTO(projectRepository.save(existing));
    }

    @Override
    public void deleteProject(Long id) {
        if (!projectRepository.existsById(id)) {
            throw new ResourceNotFoundException("Project", id);
        }
        projectRepository.deleteById(id);
    }

    private ProjectDTO toDTO(Project project) {
        return ProjectDTO.builder()
                .id(project.getId())
                .name(project.getName())
                .description(project.getDescription())
                .status(project.getStatus())
                .startDate(project.getStartDate())
                .endDate(project.getEndDate())
                .departmentId(project.getDepartment() != null ? project.getDepartment().getId() : null)
                .departmentName(project.getDepartment() != null ? project.getDepartment().getName() : null)
                .build();
    }

    private Project toEntity(ProjectDTO dto, Department department) {
        return Project.builder()
                .name(dto.getName())
                .description(dto.getDescription())
                .status(dto.getStatus())
                .startDate(dto.getStartDate())
                .endDate(dto.getEndDate())
                .department(department)
                .build();
    }
}
