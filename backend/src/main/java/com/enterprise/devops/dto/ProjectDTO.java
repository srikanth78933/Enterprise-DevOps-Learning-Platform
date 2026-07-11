package com.enterprise.devops.dto;

import com.enterprise.devops.model.entity.ProjectStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ProjectDTO {

    private Long id;

    @NotBlank(message = "Project name is required")
    @Size(max = 120, message = "Project name must be under 120 characters")
    private String name;

    @Size(max = 500, message = "Description must be under 500 characters")
    private String description;

    @NotNull(message = "Project status is required")
    private ProjectStatus status;

    private LocalDate startDate;

    private LocalDate endDate;

    @NotNull(message = "Department is required")
    private Long departmentId;

    private String departmentName;
}
