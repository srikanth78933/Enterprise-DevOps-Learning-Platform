package com.enterprise.devops.service;

import com.enterprise.devops.dto.EmployeeDTO;
import com.enterprise.devops.exception.ResourceNotFoundException;
import com.enterprise.devops.model.entity.Department;
import com.enterprise.devops.model.entity.Employee;
import com.enterprise.devops.repository.DepartmentRepository;
import com.enterprise.devops.repository.EmployeeRepository;
import com.enterprise.devops.service.impl.EmployeeServiceImpl;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class EmployeeServiceTest {

    @Mock
    private EmployeeRepository employeeRepository;

    @Mock
    private DepartmentRepository departmentRepository;

    @InjectMocks
    private EmployeeServiceImpl employeeService;

    private Department department;
    private Employee employee;
    private EmployeeDTO employeeDTO;

    @BeforeEach
    void setUp() {
        department = Department.builder().id(1L).name("Engineering").code("ENG").location("Bengaluru").build();

        employee = Employee.builder()
                .id(1L)
                .firstName("Asha")
                .lastName("Rao")
                .email("asha.rao@example.com")
                .phone("9876543210")
                .designation("Backend Engineer")
                .dateOfJoining(LocalDate.of(2023, 6, 1))
                .salary(new BigDecimal("950000"))
                .department(department)
                .build();

        employeeDTO = EmployeeDTO.builder()
                .firstName("Asha")
                .lastName("Rao")
                .email("asha.rao@example.com")
                .phone("9876543210")
                .designation("Backend Engineer")
                .dateOfJoining(LocalDate.of(2023, 6, 1))
                .salary(new BigDecimal("950000"))
                .departmentId(1L)
                .build();
    }

    @Test
    void getAllEmployees_returnsMappedList() {
        when(employeeRepository.findAll()).thenReturn(List.of(employee));

        List<EmployeeDTO> result = employeeService.getAllEmployees();

        assertThat(result).hasSize(1);
        assertThat(result.get(0).getDepartmentName()).isEqualTo("Engineering");
    }

    @Test
    void getEmployeeById_whenNotFound_throwsException() {
        when(employeeRepository.findById(42L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> employeeService.getEmployeeById(42L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void createEmployee_whenEmailUniqueAndDepartmentExists_savesEmployee() {
        when(employeeRepository.existsByEmail(employeeDTO.getEmail())).thenReturn(false);
        when(departmentRepository.findById(1L)).thenReturn(Optional.of(department));
        when(employeeRepository.save(any(Employee.class))).thenReturn(employee);

        EmployeeDTO result = employeeService.createEmployee(employeeDTO);

        assertThat(result.getId()).isEqualTo(1L);
        assertThat(result.getDepartmentName()).isEqualTo("Engineering");
    }

    @Test
    void createEmployee_whenEmailExists_throwsException() {
        when(employeeRepository.existsByEmail(employeeDTO.getEmail())).thenReturn(true);

        assertThatThrownBy(() -> employeeService.createEmployee(employeeDTO))
                .isInstanceOf(IllegalArgumentException.class);

        verify(employeeRepository, never()).save(any());
    }

    @Test
    void createEmployee_whenDepartmentMissing_throwsException() {
        when(employeeRepository.existsByEmail(employeeDTO.getEmail())).thenReturn(false);
        when(departmentRepository.findById(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> employeeService.createEmployee(employeeDTO))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void deleteEmployee_whenExists_deletesSuccessfully() {
        when(employeeRepository.existsById(1L)).thenReturn(true);

        employeeService.deleteEmployee(1L);

        verify(employeeRepository, times(1)).deleteById(1L);
    }

    @Test
    void deleteEmployee_whenNotExists_throwsException() {
        when(employeeRepository.existsById(99L)).thenReturn(false);

        assertThatThrownBy(() -> employeeService.deleteEmployee(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }
}
