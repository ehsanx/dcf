library(shiny)
library(ggplot2)

app_dir <- "." 

single_simulation_folders <- list(
  "Small_Sample_Size" = file.path("Small_Sample_Size"),
  "Large_Sample_Size" = file.path("Large_Sample_Size"),
  "Full_Data_Use" = file.path("Full_Data_Use")
)

comparison_folders <- list(
  "Sample_Size" = file.path("Sample_Size"),
  "Generalization_of_Splitting" = file.path("Generalization_of_Splitting")
)

ui <- fluidPage(
  titlePanel("Simulation Results Viewer"),
  tabsetPanel(
    tabPanel(
      "Single Simulation Results",
      sidebarLayout(
        sidebarPanel(
          radioButtons("single_simulation_folder", "Select a Simulation Setting:",
                       choices = names(single_simulation_folders),
                       selected = "Small_Sample_Size"),
          selectInput("plot", "Select a measure of Monte Carlo performance:",
                      choices = c("Bias" = "bias",
                                  "Empirical Standard Error (SE)" = "empse",
                                  "Model SE" = "modelse",
                                  "Mean squared error (MSE)" = "mse",
                                  "Relative error in Model SE" = "relerror",
                                  "Coverage probabiliy (95%)" = "cover",
                                  "Bias-eliminated coverage probabiliy (95%)" = "becover",  
                                  "Zip plot" = "zip"),
                      selected = "Bias")
        ),
        mainPanel(
          uiOutput("single_simulation_plot_output"),
          conditionalPanel(
            condition = "input.single_simulation_folder == 'Small_Sample_Size'",
            p("Note: The sample size used for this simulation was n = 3,000 (generalization 1).")
          ),
          conditionalPanel(
            condition = "input.single_simulation_folder == 'Large_Sample_Size'",
            p("Note: The sample size used for this simulation was n = 5,000 (generalization 1).")
          ),
          conditionalPanel(
            condition = "input.single_simulation_folder == 'Full_Data_Use'",
            p("Note: The sample size used for this simulation was n = 3,000 (generalization 2).")
          )
        )
      )
    ),
    tabPanel(
      "Comparison of 2 Simulations",
      sidebarLayout(
        sidebarPanel(
          radioButtons("comparison_folder", "Select a Simulation Setting:",
                       choices = names(comparison_folders),
                       selected = "Sample_Size"),
          selectInput("comparison_plot", "Select a measure of Monte Carlo performance:",
                      choices = c("Bias" = "bias",
                                  "Empirical Standard Error (SE)" = "empse",
                                  "Model SE" = "modelse",
                                  "Mean squared error (MSE)" = "mse",
                                  "Relative error in Model SE" = "relerror",
                                  "Coverage probabiliy (95%)" = "cover",
                                  "Bias-eliminated coverage probabiliy (95%)" = "becover",  
                                  "Zip plot" = "zip"),
                      selected = "Bias")
        ),
        mainPanel(
          uiOutput("comparison_plot_output"),
          conditionalPanel(
            condition = "input.comparison_folder == 'Sample_Size'",
            p("Note: This comparison is between sample sizes of (n = 3,000) and (n = 5,000) under generalization 1.")
          ),
          conditionalPanel(
            condition = "input.comparison_folder == 'Generalization_of_Splitting'",
            p("Note: This comparison is between equal split (generalization 1) and full data use (generalization 2) both with n = 3,000.")
          )
        )
      )
    ),
    tabPanel(
      "Method Descriptions",  # New Tab for Method Descriptions
      HTML("<h2>Abbreviations</h2>
        <p>TMLE: Targeted Maximum Likelihood Estimation.</p>
        <p>DCF: Double Cross-Fitting.</p>
        <p>DCF05: Double Cross-Fitting with 5 Splits or Folds.</p>
        <p>Generalization 1: Equal splits used for all 3 process: propensity score estimation, outcome model fitting and treatment effect estimation.</p>
        <p>Generalization 2: Treatment effect estimation process uses 1 split, rest of the splits are equally distributed for propensity score estimation and outcome model fitting.</p>
        
    <h2>Illustration</h2>
        <p>Example of cross-fit generalizations for 5 splits:</p>
          <div id='plotToggle'>
          <input type='radio' name='plot' value='mermaid5splits1' checked> Equal Splits (generalization 1)
          <input type='radio' name='plot' value='mermaid5splits2'> Full Data (generalization 2)
        </div>
        <div id='plotContainer'>
          <img id='mermaid5splits1' src='/app/mermaid5splits1.png' style='width:100%; display:block;'>
          <img id='mermaid5splits2' src='/app/mermaid5splits2.png' style='width:100%; display:none;'>
        </div>
      <input type='range' id='sizeSlider' min='50' max='100' value='75'>
      <script>
        $('input[name=plot]').change(function() {
        var selectedPlot = $(this).val();
        $('#plotContainer img').hide();
        $('#' + selectedPlot).show();
      });

        $('#sizeSlider').on('input', function() {
        var size = $(this).val() + '%';
        $('#plotContainer img').css('width', size);
      });
    </script>
        <h2>Data Generation</h2>
        <p>Based on Zivich and Breskin article</p>
        
        <h2>References</h2>
        <ol>
          <li>Victor Chernozhukov, Denis Chetverikov, Mert Demirer, Esther Duflo, Christian Hansen, Whitney Newey, and James Robins. Double/debiased machine learning for treatment and structural parameters. The Econometrics Journal, 21:1–68, 2018. doi: 10.1111/ectj.12097.</li>
          <li>Whitney K Newey and James R Robins. Cross-fitting and fast remainder rates for semiparametric estimation. arXiv preprint arXiv:1801.09138, 2018.</li>
          <li>Mark J Van der Laan, Sherri Rose, et al. Targeted learning: causal inference for observational and experimental data, volume 10. New York; Springer, 2011.</li>
          <li>Yongqi Zhong, Edward H Kennedy, Lisa M Bodnar, and Ashley I Naimi. Aipw: an r package for augmented inverse probability–weighted estimation of average causal effects. American Journal of Epidemiology, 190(12):2690–2699, 2021.</li>
        </ol>
        
        <h2>Software References</h2>
        <ol>
          <li>Momenul H Mondol and Mohammad Ehsanul Karim. Crossfit: An r package to apply sample splitting (cross-fit) to aipw and tmle in causal inference, 2023. https://github.com/momenulhaque/Crossfit.</li>
          <li>Alessandro Gasparini. rsimsum: Summarise results from monte carlo simulation studies. Journal of Open Source Software, 3: 739, 2018. doi: 10.21105/joss.00739.</li>
        </ol>")
    )
    
    
    
  )
)


server <- function(input, output, session) {
  addResourcePath("app", file.path("app"))
  output$single_simulation_plot_output <- renderUI({
    folder <- input$single_simulation_folder
    plot_type <- input$plot
    if (!is.null(folder) && !is.null(plot_type)) {
      # Construct the file path for the selected plot
      file_path <- file.path(single_simulation_folders[[folder]], paste0(plot_type, ".png"))
      # Serve the image file
      img_src <- sprintf("/%s/%s.png", folder, plot_type)
      addResourcePath(folder, single_simulation_folders[[folder]])
      img(src = img_src, width = "100%")
    }
  })
  
  output$comparison_plot_output <- renderUI({
    folder <- input$comparison_folder
    plot_type <- input$comparison_plot
    if (!is.null(folder) && !is.null(plot_type)) {
      # Construct the file path for the selected plot
      file_path <- file.path(comparison_folders[[folder]], paste0(plot_type, ".png"))
      # Serve the image file
      img_src <- sprintf("/%s/%s.png", folder, plot_type)
      addResourcePath(folder, comparison_folders[[folder]])
      img(src = img_src, width = "100%")
    }
  })
}

shinyApp(ui, server)