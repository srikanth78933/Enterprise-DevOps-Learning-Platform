package com.enterprise.devops.service;

import com.enterprise.devops.dto.ProjectDTO;
import com.enterprise.devops.exception.ResourceNotFoundException;
import com.enterprise.devops.model.entity.Department;
import com.enterprise.devops.model.entity.Project;
import com.enterprise.devops.model.entity.ProjectStatus;
import com.enterprise.devops.repository.DepartmentRepository;
import com.enterprise.devops.repository.ProjectRepository;
import com.enterprise.devops.service.impl.ProjectServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProjectServiceTest {

    @Mock
    private ProjectRepository projectRepository;

    @Mock
    private DepartmentRepository departmentRepository;

    @InjectMocks
    private ProjectServiceImpl projectService;

    private Department department;
    private Project project;
    private ProjectDTO projectDTO;

    @BeforeEach
    void setUp() {
        department = Department.builder().id(1L).name("Engineering").code("ENG").location("Bengaluru").build();

        project = Project.builder()
                .id(1L)
                .name("Platform Migration")
                .description("Migrate monolith to microservices")
                .status(ProjectStatus.IN_PROGRESS)
                .startDate(LocalDate.of(2026, 1, 1))
                .department(department)
                .build();

        projectDTO = ProjectDTO.builder()
                .name("Platform Migration")
                .description("Migrate monolith to microservices")
                .status(ProjectStatus.IN_PROGRESS)
                .startDate(LocalDate.of(2026, 1, 1))
                .departmentId(1L)
                .build();
    }

    @Test
    void getAllProjects_returnsMappedList() {
        when(projectRepository.findAll()).thenReturn(List.of(project));

        List<ProjectDTO> result = projectService.getAllProjects();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getStatus()).isEqualTo(ProjectStatus.IN_PROGRESS);
    }

    @Test
    void getProjectById_whenNotFound_throwsException() {
        when(projectRepository.findById(5L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> projectService.getProjectById(5L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void createProject_whenDepartmentExists_savesProject() {
        when(departmentRepository.findById(1L)).thenReturn(Optional.of(department));
        when(projectRepository.save(any(Project.class))).thenReturn(project);

        ProjectDTO result = projectService.createProject(projectDTO);

        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getDepartmentName()).isEqualTo("Engineering");
    }

    @Test
    void createProject_whenDepartmentMissing_throwsException() {
        when(departmentRepository.findById(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> projectService.createProject(projectDTO))
                .isInstanceOf(ResourceNotFoundException.class);

        verify(projectRepository, never()).save(any());
    }

    @Test
    void deleteProject_whenExists_deletesSuccessfully() {
        when(projectRepository.existsById(1L)).thenReturn(true);

        projectService.deleteProject(1L);

        verify(projectRepository, times(1)).deleteById(1L);
    }

    @Test
    void deleteProject_whenNotExists_throwsException() {
        when(projectRepository.existsById(99L)).thenReturn(false);

        assertThatThrownBy(() -> projectService.deleteProject(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
