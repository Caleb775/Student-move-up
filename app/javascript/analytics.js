// Analytics Dashboard JavaScript
import Chart from 'chart.js/auto';

console.log('Analytics.js loaded, Chart.js available:', typeof Chart);

document.addEventListener('DOMContentLoaded', function() {
  console.log('DOM loaded, initializing charts...');
  // Initialize all charts when the page loads
  initializeCharts();
});

document.addEventListener('turbo:load', function() {
  console.log('Turbo loaded, initializing charts...');
  // Reinitialize charts on Turbo navigation
  initializeCharts();
});

function initializeCharts() {
  console.log('initializeCharts called');
  
  // Performance Trend Chart
  const performanceCtx = document.getElementById('performanceChart');
  console.log('Performance chart canvas:', performanceCtx);
  if (performanceCtx) {
    createPerformanceChart(performanceCtx);
  } else {
    console.log('Performance chart canvas not found');
  }

  // Skills Distribution Chart
  const skillsCtx = document.getElementById('skillsChart');
  console.log('Skills chart canvas:', skillsCtx);
  if (skillsCtx) {
    createSkillsChart(skillsCtx);
  } else {
    console.log('Skills chart canvas not found');
  }

  // Student Distribution Chart
  const distributionCtx = document.getElementById('distributionChart');
  console.log('Distribution chart canvas:', distributionCtx);
  if (distributionCtx) {
    createDistributionChart(distributionCtx);
  } else {
    console.log('Distribution chart canvas not found');
  }

  // Score Range Chart
  const scoreRangeCtx = document.getElementById('scoreRangeChart');
  console.log('Score range chart canvas:', scoreRangeCtx);
  if (scoreRangeCtx) {
    createScoreRangeChart(scoreRangeCtx);
  } else {
    console.log('Score range chart canvas not found');
  }
}

function createPerformanceChart(ctx) {
  console.log('Creating performance chart with test data...');
  
  // First, let's try with test data to see if Chart.js works
  try {
    new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
        datasets: [{
          label: 'Average Score',
          data: [12, 19, 3, 5, 2, 3],
          borderColor: 'rgb(75, 192, 192)',
          backgroundColor: 'rgba(75, 192, 192, 0.2)',
          tension: 0.1,
          fill: true
        }, {
          label: 'Top Score',
          data: [2, 3, 20, 5, 1, 4],
          borderColor: 'rgb(255, 99, 132)',
          backgroundColor: 'rgba(255, 99, 132, 0.2)',
          tension: 0.1,
          fill: true
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Performance Trends Over Time'
          },
          legend: {
            position: 'top'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            max: 40
          }
        }
      }
    });
    console.log('Test chart created successfully');
  } catch (error) {
    console.error('Error creating test chart:', error);
  }
}

function createSkillsChart(ctx) {
  console.log('Creating skills chart with test data...');
  
  try {
    new Chart(ctx, {
      type: 'radar',
      data: {
        labels: ['Reading', 'Writing', 'Listening', 'Speaking'],
        datasets: [{
          label: 'Average Skills',
          data: [8, 7, 9, 6],
          borderColor: 'rgb(54, 162, 235)',
          backgroundColor: 'rgba(54, 162, 235, 0.2)',
          pointBackgroundColor: 'rgb(54, 162, 235)',
          pointBorderColor: '#fff',
          pointHoverBackgroundColor: '#fff',
          pointHoverBorderColor: 'rgb(54, 162, 235)'
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Skills Distribution'
          }
        },
        scales: {
          r: {
            beginAtZero: true,
            max: 10
          }
        }
      }
    });
    console.log('Skills chart created successfully');
  } catch (error) {
    console.error('Error creating skills chart:', error);
  }
}

function createDistributionChart(ctx) {
  console.log('Creating distribution chart with test data...');
  
  try {
    new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['Excellent (90%+)', 'Good (80-89%)', 'Average (70-79%)', 'Below Average (60-69%)', 'Needs Improvement (<60%)'],
        datasets: [{
          data: [5, 8, 12, 3, 2],
          backgroundColor: [
            '#FF6384',
            '#36A2EB',
            '#FFCE56',
            '#4BC0C0',
            '#9966FF'
          ],
          hoverBackgroundColor: [
            '#FF6384',
            '#36A2EB',
            '#FFCE56',
            '#4BC0C0',
            '#9966FF'
          ]
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Score Distribution'
          },
          legend: {
            position: 'bottom'
          }
        }
      }
    });
    console.log('Distribution chart created successfully');
  } catch (error) {
    console.error('Error creating distribution chart:', error);
  }
}

function createScoreRangeChart(ctx) {
  console.log('Creating score range chart with test data...');
  
  try {
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: ['0-10', '11-20', '21-30', '31-35', '36-40'],
        datasets: [{
          label: 'Number of Students',
          data: [2, 5, 8, 10, 5],
          backgroundColor: [
            'rgba(255, 99, 132, 0.8)',
            'rgba(54, 162, 235, 0.8)',
            'rgba(255, 205, 86, 0.8)',
            'rgba(75, 192, 192, 0.8)',
            'rgba(153, 102, 255, 0.8)'
          ],
          borderColor: [
            'rgba(255, 99, 132, 1)',
            'rgba(54, 162, 235, 1)',
            'rgba(255, 205, 86, 1)',
            'rgba(75, 192, 192, 1)',
            'rgba(153, 102, 255, 1)'
          ],
          borderWidth: 1
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Students by Score Range'
          }
        },
        scales: {
          y: {
            beginAtZero: true
          }
        }
      }
    });
    console.log('Score range chart created successfully');
  } catch (error) {
    console.error('Error creating score range chart:', error);
  }
}
