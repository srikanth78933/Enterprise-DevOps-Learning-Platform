package com.enterprise.devops.service;

import com.enterprise.devops.dto.DepartmentDTO;
import com.enterprise.devops.exception.ResourceNotFoundException;
import com.enterprise.devops.model.entity.Department;
import com.enterprise.devops.repository.DepartmentRepository;
import com.enterprise.devops.service.impl.DepartmentServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class DepartmentServiceTest {

    @Mock
    private DepartmentRepository departmentRepository;

    @InjectMocks
    private DepartmentServiceImpl departmentService;

    private Department department;
    private DepartmentDTO departmentDTO;

    @BeforeEach
    void setUp() {
        department = Department.builder()
                .id(1L)
                .name("Engineering")
                .code("ENG")
                .location("Bengaluru")
                .build();

        departmentDTO = DepartmentDTO.builder()
                .name("Engineering")
                .code("ENG")
                .location("Bengaluru")
                .build();
    }

    @Test
    void getAllDepartments_returnsMappedList() {
        when(departmentRepository.findAll()).thenReturn(List.of(department));

        List<DepartmentDTO> result = departmentService.getAllDepartments();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getCode()).isEqualTo("ENG");
    }

    @Test
    void getDepartmentById_whenFound_returnsDTO() {
        when(departmentRepository.findById(1L)).thenReturn(Optional.of(department));

        DepartmentDTO result = departmentService.getDepartmentById(1L);

        assertThat(result.getName()).isEqualTo("Engineering");
    }

    @Test
    void getDepartmentById_whenNotFound_throwsException() {
        when(departmentRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> departmentService.getDepartmentById(99L))
                .isInstanceOf(ResourceNotFoundException.class)
                .hasMessageContaining("99");
    }

    @Test
    void createDepartment_whenCodeUnique_savesDepartment() {
        when(departmentRepository.existsByCode("ENG")).thenReturn(false);
        when(departmentRepository.save(any(Department.class))).thenReturn(department);

        DepartmentDTO result = departmentService.createDepartment(departmentDTO);

        assertThat(result.getId()).isEqualTo(1L);
        verify(departmentRepository, times(1)).save(any(Department.class));
    }

    @Test
    void createDepartment_whenCodeExists_throwsException() {
        when(departmentRepository.existsByCode("ENG")).thenReturn(true);

        assertThatThrownBy(() -> departmentService.createDepartment(departmentDTO))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("ENG");

        verify(departmentRepository, never()).save(any());
    }

    @Test
    void updateDepartment_whenFound_updatesFields() {
        DepartmentDTO updateRequest = DepartmentDTO.builder()
                .name("Platform Engineering")
                .code("ENG")
                .location("Hyderabad")
                .build();

        when(departmentRepository.findById(1L)).thenReturn(Optional.of(department));
        when(departmentRepository.save(any(Department.class))).thenAnswer(invocation -> invocation.getArgument(0));

        DepartmentDTO result = departmentService.updateDepartment(1L, updateRequest);

        assertThat(result.getName()).isEqualTo("Platform Engineering");
        assertThat(result.getLocation()).isEqualTo("Hyderabad");
    }

    @Test
    void deleteDepartment_whenExists_deletesSuccessfully() {
        when(departmentRepository.existsById(1L)).thenReturn(true);
        doNothing().when(departmentRepository).deleteById(1L);

        departmentService.deleteDepartment(1L);

        verify(departmentRepository, times(1)).deleteById(1L);
    }

    @Test
    void deleteDepartment_whenNotExists_throwsException() {
        when(departmentRepository.existsById(anyLong())).thenReturn(false);

        assertThatThrownBy(() -> departmentService.deleteDepartment(99L))
                .isInstanceOf(ResourceNotFoundException.class);

        verify(departmentRepository, never()).deleteById(anyLong());
    }
}
