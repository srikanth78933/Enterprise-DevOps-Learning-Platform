package com.enterprise.devops.controller;

import com.enterprise.devops.dto.DepartmentDTO;
import com.enterprise.devops.exception.ResourceNotFoundException;
import com.enterprise.devops.service.DepartmentService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.web.servlet.MockMvc;

import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(DepartmentController.class)
class DepartmentControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private ObjectMapper objectMapper;

    @MockBean
    private DepartmentService departmentService;

    @Test
    void getAllDepartments_returnsOkWithList() throws Exception {
        DepartmentDTO department = DepartmentDTO.builder()
                .id(1L).name("Engineering").code("ENG").location("Bengaluru").build();

        when(departmentService.getAllDepartments()).thenReturn(List.of(department));

        mockMvc.perform(get("/api/departments"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].code").value("ENG"));
    }

    @Test
    void getDepartmentById_whenNotFound_returns404WithApiError() throws Exception {
        when(departmentService.getDepartmentById(99L))
                .thenThrow(new ResourceNotFoundException("Department", 99L));

        mockMvc.perform(get("/api/departments/{id}", 99L))
                .andExpect(status().isNotFound())
                .andExpect(jsonPath("$.status").value(404))
                .andExpect(jsonPath("$.message").value("Department not found with id: 99"));
    }

    @Test
    void createDepartment_whenPayloadInvalid_returns400() throws Exception {
        DepartmentDTO invalid = DepartmentDTO.builder().name("").code("").build();

        mockMvc.perform(post("/api/departments")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(invalid)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.fieldErrors.name").exists());
    }

    @Test
    void createDepartment_whenPayloadValid_returns201() throws Exception {
        DepartmentDTO request = DepartmentDTO.builder().name("Engineering").code("ENG").location("Bengaluru").build();
        DepartmentDTO created = DepartmentDTO.builder().id(1L).name("Engineering").code("ENG").location("Bengaluru").build();

        when(departmentService.createDepartment(any(DepartmentDTO.class))).thenReturn(created);

        mockMvc.perform(post("/api/departments")
                        .contentType("application/json")
                        .content(objectMapper.writeValueAsString(request)))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.id").value(1));
    }

    @Test
    void deleteDepartment_returnsNoContent() throws Exception {
        mockMvc.perform(delete("/api/departments/{id}", 1L))
                .andExpect(status().isNoContent());
    }
}
