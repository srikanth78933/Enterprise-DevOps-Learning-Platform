package com.enterprise.devops.dto;

import jakarta.validation.constraints.*;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class EmployeeDTO {

    private Long id;

    @NotBlank(message = "First name is required")
    @Size(max = 50, message = "First name must be under 50 characters")
    private String firstName;

    @NotBlank(message = "Last name is required")
    @Size(max = 50, message = "Last name must be under 50 characters")
    private String lastName;

    @NotBlank(message = "Email is required")
    @Email(message = "Email must be valid")
    private String email;

    @Pattern(regexp = "^$|^[0-9+\\-() ]{7,20}$", message = "Phone number is invalid")
    private String phone;

    @Size(max = 80, message = "Designation must be under 80 characters")
    private String designation;

    private LocalDate dateOfJoining;

    @PositiveOrZero(message = "Salary must be zero or positive")
    private BigDecimal salary;

    @NotNull(message = "Department is required")
    private Long departmentId;

    // Populated on responses for display convenience; ignored on write.
    private String departmentName;
}
